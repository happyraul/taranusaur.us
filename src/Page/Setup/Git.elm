module Page.Setup.Git exposing (Model, Msg, init, toSession, update, view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Page
import Session



-- MODEL


type alias Model =
    { activeLink : Maybe String
    , session : Session.Session
    }


init : Session.Session -> Model
init session =
    Model Nothing session



-- UPDATE


type Msg
    = HoveredLink String
    | UnHoveredLink


update : Msg -> Model -> Model
update msg model =
    case msg of
        HoveredLink link ->
            { model | activeLink = Just link }

        UnHoveredLink ->
            { model | activeLink = Nothing }



-- VIEW


edges =
    { top = 0, right = 0, bottom = 0, left = 0 }


view : Model -> { title : String, content : Element Msg }
view model =
    { title = "Setup Git Server"
    , content =
        textColumn [ spacing 15, width fill ]
            [ viewIntro
            , viewConfigureDns
            , viewInstallGit
            , viewCreateUser
            , viewSecurity
            , viewAddSshKeys
            , viewCreateRepository
            ]
    }


viewIntro : Element msg
viewIntro =
    paragraph []
        [ text
            ("These instructions are for setting up a git server. "
                ++ "See also: "
            )
        , link [ Font.color Page.colors.link ]
            { url = "/setup-vps"
            , label = text "Setup VPS & nginx"
            }
        , text ".  Much of this is taken verbatim from the "
        , link [ Font.color Page.colors.link ]
            { url =
                "https://git-scm.com/book/en/v2/"
                    ++ "Git-on-the-Server-The-Protocols"
            , label = text "Git Book"
            }
        , text ", where one can find a lot more detail about git servers."
        ]


viewConfigureDns : Element msg
viewConfigureDns =
    textColumn [ width fill, spacing 15 ]
        [ viewHeading "Configure DNS"
        , instructions
            [ text "Using the DNS management for the nameserver, create a "
            , code "CNAME"
            , text " record from the "
            , code "git"
            , text " subdomain to the top-level domain."
            ]
        , paragraph [ paddingEach { edges | top = 10 } ]
            [ text
                ("The record should look something like this (note the "
                    ++ "trailing "
                )
            , code "."
            , text ", which is required by some providers):"
            ]
        , viewDnsRecords
        ]


viewDnsRecords : Element msg
viewDnsRecords =
    let
        border : List (Attribute msg)
        border =
            [ Border.color Page.colors.lightgrey
            , Border.widthEach { edges | bottom = 1 }
            ]

        viewHeader : String -> Element msg
        viewHeader label =
            el
                (border
                    ++ [ Font.heavy
                       , paddingEach { edges | bottom = 15 }
                       ]
                )
                (text label)

        viewType : Bool -> String -> Element msg
        viewType last type_ =
            let
                base =
                    [ Font.heavy
                    , paddingEach { edges | bottom = 15, top = 15 }
                    ]

                attributes =
                    if last then
                        base

                    else
                        border ++ base
            in
            el attributes (el [ padding 4 ] <| text type_)

        viewLiteral : Bool -> String -> Element msg
        viewLiteral last data =
            let
                base =
                    [ Font.family [ Font.monospace ]
                    , paddingEach { edges | bottom = 15, top = 15 }
                    ]

                attributes =
                    if last then
                        base

                    else
                        border ++ base
            in
            el attributes
                (el [ Background.color Page.colors.reallyLightPink, padding 4 ]
                    (text data)
                )
    in
    table
        [ Background.color Page.colors.reallyLightBlue
        , padding 10
        , width fill
        ]
        { columns =
            [ { header = viewHeader "Type"
              , width = fillPortion 1
              , view = \record -> viewType record.last record.type_
              }
            , { header = viewHeader "Domain"
              , width = fillPortion 2
              , view = \record -> viewLiteral record.last record.domain
              }
            , { header = viewHeader "Data"
              , width = fillPortion 3
              , view = \record -> viewLiteral record.last record.data
              }
            ]
        , data =
            [ { type_ = "CNAME"
              , domain = "git.taranusaur.us"
              , data = "taranusaur.us."
              , last = True
              }
            ]
        }


viewInstallGit : Element msg
viewInstallGit =
    textColumn [ width fill, spacing 15 ]
        [ viewHeading "Install Git"
        , instructions
            [ text "Install the "
            , code "git"
            , text " package:"
            ]
        , codeBlock [ "# apt update && apt install git" ]
        ]


viewCreateUser : Element msg
viewCreateUser =
    textColumn [ width fill, spacing 15 ]
        [ viewHeading "Create git user"
        , instructions
            [ text "SSH to the "
            , link [ Font.color Page.colors.link ]
                { url = "/setup-vps"
                , label = text "server"
                }
            , text " and create a "
            , code "git"
            , text " user account and a"
            , code ".ssh"
            , text " directory for that user:"
            ]
        , codeBlock
            [ "# adduser git"
            , "# su git"
            , "$ cd"
            , "$ mkdir .ssh && chmod 700 .ssh"
            , "$ touch .ssh/authorized_keys && chmod 600 .ssh/authorized_keys"
            ]
        ]


viewSecurity : Element msg
viewSecurity =
    textColumn [ width fill, spacing 15 ]
        [ viewHeading "Restrict user access"
        , instructions
            [ text "We want to restrict the "
            , code "git"
            , text
                (" user account to only Git-related activities with a limited "
                    ++ "shell tool called "
                )
            , code "git-shell"
            , text " that comes with Git.  By setting this as the "
            , code "git"
            , text
                (" user account's login shell, that account will not have "
                    ++ "normal shell access to the server. First, the full "
                    ++ "pathname of the "
                )
            , code "git-shell"
            , text " command must be added to "
            , code "/etc/shells"
            , text " if it's not already there:"
            ]
        , codeBlock
            [ "# cat /etc/shells   # see if git-shell is already in there..."
            , "# which git-shell   # make sure git-shell is installed"
            , "/usr/bin/git-shell"
            , "# vim /etc/shells   # add the path to git-shell from above"
            ]
        , codeFile "/etc/shells"
            [ "# /etc/shells: valid login shells"
            , "/usr/bin/git-shell"
            , "/bin/sh"
            , "/bin/bash"
            , "..."
            ]
        , instructions
            [ text "Set the shell for the "
            , code "git"
            , text " user:"
            ]
        , codeBlock [ "# chsh git -s $(which git-shell)" ]
        , instructions
            [ text "Now the "
            , code "git"
            , text
                (" user can still use the SSH connection to push and pull Git "
                    ++ "repositories but can't shell onto the machine:"
                )
            ]
        , codeBlock
            [ "$ ssh git@taranusaur.us"
            , "fatal: Interactive git shell is not enabled."
            , "hint: ~/git-shell-commands should exist and have read and "
                ++ "execute access."
            , "Connection to taranusaur.us closed."
            ]
        , instructions
            [ text
                ("SSH port forwarding is still available to users logging in "
                    ++ "as the "
                )
            , code "git"
            , text
                (" user, so that should be disabled by prepending the "
                    ++ "following options to each key in the "
                )
            , code "authorized_keys"
            , text "file:"
            ]
        , codeBlock
            [ "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty"
            ]
        , instructions [ text "The result should look like this:" ]
        , codeFile "/home/git/.ssh/authorized_keys"
            [ "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,"
                ++ "no-pty ssh-rsa"
            , "AAAAB3NzaC1yc2EAAAADAQABAAABAQCB007n/ww+ouN4gSLKssMxXnBOvf9LGt4"
                ++ "LojG6rs6h"
            , "PB09j9R/T17/x4lhJA0F3FR1rP6kYBRsWj2aThGw6HXLm9/5zytK6Ztg3RPKK+4"
                ++ "kYjh6541N"
            , "YsnEAZuXz0jTTyAUfrtU3Z5E003C4oxOj6H0rfIF1kKI9MAQLMdpGW1GYEIgS9E"
                ++ "zSdfd8AcC"
            , "IicTDWbqLAcU4UpkaX8KyGlLwsNuuGztobF8m72ALC/nLF6JLtPofwFBlgc+myi"
                ++ "vO7TCUSBd"
            , "LQlgMVOFq1I2uPWQOkOWQAHukEOmfjy2jctxSDBQ220ymjaNsHT4kgtZg2AYYgP"
                ++ "qdAv8JggJ"
            , "ICUvax2T9va5 gsg-keypair"
            , ""
            , "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,"
                ++ "no-pty ssh-rsa"
            , "AAAAB3NzaC1yc2EAAAADAQABAAABAQDEwENNMomTboYI+LJieaAY16qiXiH3wuv"
                ++ "ENhBG..."
            ]
        ]


viewAddSshKeys : Element msg
viewAddSshKeys =
    textColumn [ width fill, spacing 15 ]
        [ viewHeading "Add SSH keys"
        , instructions
            [ text
                ("Add public keys from the individuals who should have "
                    ++ "access. First, copy public keys to the server:"
                )
            ]
        , codeBlock
            [ "$ scp ~/.ssh/id_rsa.pub "
                ++ "root@taranusaur.us:/tmp/id_rsa.taranusaurus.pub"
            ]
        , instructions
            [ text "Then, on the server, append them to the "
            , code "git"
            , text " user's "
            , code "authorized_keys"
            , text " file in its "
            , code ".ssh"
            , text " directory:"
            ]
        , codeBlock
            [ "# cat /tmp/id_rsa.taranusaurus.pub >> ~/.ssh/authorized_keys" ]
        , instructions
            [ text "Now it should be possible to connect to the server as the "
            , code "git"
            , text " user:"
            ]
        , codeBlock
            [ "$ ssh git@taranusaur.us" ]
        ]


viewCreateRepository : Element msg
viewCreateRepository =
    textColumn [ width fill, spacing 15 ]
        [ viewHeading "Create empty repository"
        , instructions
            [ text "Choose a location for the repositories and give the "
            , code "git"
            , text "user ownership:"
            ]
        , codeBlock
            [ "# mkdir /var/www/git"
            , "# chown git:git /var/www/git/"
            ]
        , instructions
            [ text "Set up an empty repository by running "
            , code "git init"
            , text " with the "
            , code "--bare"
            , text
                (" option, which initializes the repository without a working "
                    ++ "directory. This should always be done as the "
                )
            , code "git"
            , text " user:"
            ]
        , codeBlock
            [ "# su git -s /bin/bash"
            , "$ cd /var/www/git"
            , "$ mkdir taranusaurus.git"
            , "$ cd taranusaurus.git"
            , "$ git init --bare"
            , "Initialized empty Git repository in "
                ++ "/var/www/git/taranusaurus.git"
            ]
        , instructions
            [ text
                ("Now it should be possible to push to this repository by "
                    ++ "adding it as a remote and pushing up a branch."
                )
            ]
        , note
            (text
                ("A bare repository must be created on the server for every "
                    ++ "project one wants to host."
                )
            )
        , instructions
            [ text
                "Add the remote on a client computer, and push to the server:"
            ]
        , codeBlock
            [ "$ cd taranusaur.us"
            , "$ git init"
            , "$ git add ."
            , "$ git commit -m 'Initial commit'"
            , "$ git remote add origin "
                ++ "git@git.taranusaur.us:/var/www/git/taranusaurus.git"
            , "$ git push origin master"
            ]
        ]


code : String -> Element msg
code inner =
    el
        [ Background.color Page.colors.reallyLightBlue
        , paddingEach { edges | top = 1, bottom = 3, left = 5, right = 5 }
        , Font.family [ Font.monospace ]
        ]
        (text inner)


codeBlock : List String -> Element msg
codeBlock lines =
    column
        [ Background.color Page.colors.reallyLightBlue
        , paddingEach { edges | top = 20, bottom = 20, left = 15, right = 15 }
        , Border.color Page.colors.lightgrey
        , Border.width 1
        , Font.family [ Font.monospace ]
        , spacing 3
        ]
        (List.map text lines)


codeFile : String -> List String -> Element msg
codeFile file lines =
    column
        [ Background.color Page.colors.reallyLightBlue
        , Border.color Page.colors.lightgrey
        , Border.width 1
        , Font.family [ Font.monospace ]
        ]
        [ el
            [ Border.color Page.colors.lightgrey
            , Border.dashed
            , Border.widthEach { edges | bottom = 1 }
            , paddingEach
                { edges | top = 20, bottom = 20, left = 15, right = 15 }
            , width fill
            ]
            (text file)
        , column
            [ paddingEach
                { edges | top = 20, bottom = 20, left = 15, right = 15 }
            , spacing 3
            ]
            (List.map text lines)
        ]


note : Element msg -> Element msg
note inner =
    column
        [ Background.color Page.colors.paleLavender
        , paddingEach { edges | top = 20, bottom = 20, left = 15, right = 15 }
        , Border.color Page.colors.lightgrey
        , Border.width 1
        , spacing 15
        , width fill
        ]
        [ el [ Font.heavy ] <| text "Note:"
        , inner
        ]


instructions : List (Element msg) -> Element msg
instructions steps =
    paragraph [ paddingEach { edges | top = 20 } ] steps


viewHeading : String -> Element msg
viewHeading heading =
    el
        [ Font.size 28
        , Font.heavy
        , paddingEach { edges | top = 15, bottom = 5 }
        , Border.widthEach { edges | bottom = 1 }
        , Border.color Page.colors.primary
        , Font.color Page.colors.primary
        ]
        (text heading)


viewLink : Maybe String -> String -> String -> Element Msg
viewLink activeLink url page =
    let
        baseAttributes =
            [ Font.color Page.colors.link
            , Events.onMouseEnter (HoveredLink page)
            , Events.onMouseLeave UnHoveredLink
            ]

        attributes =
            case activeLink of
                Just link ->
                    if link == page then
                        Font.underline :: baseAttributes

                    else
                        baseAttributes

                Nothing ->
                    baseAttributes
    in
    link attributes { url = url, label = text page }



-- EXPORT


toSession : Model -> Session.Session
toSession model =
    model.session
