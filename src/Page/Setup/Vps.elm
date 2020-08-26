module Page.Setup.Vps exposing (Model, Msg, init, toSession, update, view)

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
    { title = "Setup VPS & nginx"
    , content =
        textColumn [ spacing 15, width fill ]
            [ paragraph []
                [ text
                    "These instructions are for setting up a server on a "
                , link [ Font.color Page.colors.link ]
                    { url = "https://www.vultr.com/"
                    , label = text "Vultr"
                    }
                , text
                    (" VPS instance.  It is assumed that a domain name has "
                        ++ "been registered, in this case "
                    )
                , code "taranusaur.us"
                , text "."
                ]
            , viewDeploy
            , viewConfigureDns
            , viewConfigureSsh
            , viewInstallPackages
            , viewConfigureNginx
            , viewCreateCert
            ]
    }


viewDeploy : Element msg
viewDeploy =
    textColumn [ width fill, spacing 15 ]
        [ viewHeading "Deploy new instance"
        , instructions
            [ text "1. In the "
            , link [ Font.color Page.colors.link ]
                { url = "https://my.vultr.com/deploy/"
                , label = text "deployment console"
                }
            , text ", select the "
            , code "Cloud Compute"
            , text " server type:"
            ]
        , image []
            { src = "/static/img/choose-server.png"
            , description = "Choose Server"
            }
        , instructions
            [ text "2. Select the "
            , code "New York (NJ)"
            , text " location:"
            ]
        , image []
            { src = "/static/img/server-location.png"
            , description = "Server Location"
            }
        , instructions
            [ text "3. Select "
            , code "Debian 10 x64"
            , text " for the OS:"
            ]
        , image []
            { src = "/static/img/server-type.png"
            , description = "Server Type"
            }
        , instructions
            [ text "4. Select the cheapest option that includes "
            , code "IPv4"
            , text " (don't choose one that is "
            , code "IPv6 ONLY"
            , text "):"
            ]
        , image []
            { src = "/static/img/server-size.png"
            , description = "Server Size"
            }
        , instructions
            [ text "5. Select the "
            , code "Enable IPv6"
            , text ", and optionally, the "
            , code "Block Storage Compatible"
            , text " additional features:"
            ]
        , image []
            { src = "/static/img/additional-features.png"
            , description = "Additional Features"
            }
        , instructions
            [ text "6. Enter a hostname and click "
            , code "Deploy Now"
            , text "."
            ]
        ]


viewConfigureDns : Element msg
viewConfigureDns =
    textColumn [ width fill, spacing 15 ]
        [ viewHeading "Configure DNS"
        , instructions
            [ text
                ("Once the server is up and running, find its IP "
                    ++ "addresses (both "
                )
            , code "IPv4"
            , text " and "
            , code "IPv6"
            , text ")."
            ]
        , paragraph [ paddingEach { edges | top = 10 } ]
            [ text
                "1. Using the DNS management for the nameserver, create an "
            , code "A"
            , text " record from the domain name to the "
            , code "IPv4"
            , text " address."
            ]
        , paragraph []
            [ text "2. Create an "
            , code "AAAA"
            , text " record from the domain name to the "
            , code "IPv6"
            , text " address."
            ]
        , paragraph []
            [ text "3. Create a "
            , code "CNAME"
            , text " from the "
            , code "www"
            , text " subdomain to the top-level domain."
            ]
        , paragraph [ paddingEach { edges | top = 10 } ]
            [ text
                ("The records should look something like this (note the "
                    ++ "trailing "
                )
            , code "."
            , text " in the "
            , code "CNAME"
            , text " entry, which is required by some providers):"
            ]
        , viewDnsRecords
        , instructions
            [ text
                ("After a short while, the server should be reachable via its "
                    ++ "domain name."
                )
            ]
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
            [ { type_ = "A"
              , domain = "taranusaur.us"
              , data = "45.77.96.176"
              , last = False
              }
            , { type_ = "AAAA"
              , domain = "taranusaur.us"
              , data = "2001:19f0:5:12b1:5400:02ff:feec:c163"
              , last = False
              }
            , { type_ = "CNAME"
              , domain = "www.taranusaur.us"
              , data = "taranusaur.us."
              , last = True
              }
            ]
        }


viewConfigureSsh : Element msg
viewConfigureSsh =
    textColumn [ width fill, spacing 15 ]
        [ viewHeading "Configure SSH"
        , instructions
            [ text
                ("Copy public ssh key to the server using the root password "
                    ++ "shown on the overview page of the instance:"
                )
            ]
        , codeBlock "$ ssh-copy-id -i ~/.ssh/id_rsa.pub root@taranusaur.us"
        , instructions
            [ text "Connect to the server:" ]
        , codeBlock "$ ssh root@taranusaur.us"
        , instructions
            [ text "Edit "
            , code "/etc/ssh/sshd_config"
            , text " and disable access by password (ensure it is "
            , code "sshd_config"
            , text ", and "
            , el [ Font.heavy ] <| text "NOT "
            , code "ssh_config"
            , text "):"
            ]
        , codeFile "/etc/ssh/sshd_config"
            [ "PasswordAuthentication no"
            , "UsePAM no"
            , "ChallengeResponseAuthentication no"
            ]
        , instructions
            [ text "Restart the SSH daemon:" ]
        , codeBlock "# systemctl restart sshd"
        , instructions
            [ text
                ("Now it should no longer be possible to log in to the server "
                    ++ "via the root password."
                )
            ]
        ]


viewInstallPackages : Element msg
viewInstallPackages =
    textColumn [ width fill, spacing 15 ]
        [ viewHeading "Install packages"
        , instructions
            [ text "Install updates (on the server):" ]
        , codeBlock "# apt update && apt upgrade"
        , instructions
            [ text "Install "
            , code "nginx"
            , text ", "
            , code "certbot"
            , text ", and "
            , code "python-certbot-nginx"
            , text " packages:"
            ]
        , codeBlock "# apt install nginx certbot python-certbot-nginx"
        ]


viewConfigureNginx : Element msg
viewConfigureNginx =
    textColumn [ width fill, spacing 15 ]
        [ viewHeading "Configure nginx"
        , instructions
            [ text
                ("Create the root directory for the site, and add some stub "
                    ++ "content:"
                )
            ]
        , codeBlock
            ("# mkdir /var/www/taranusaur.us\n"
                ++ "# echo \"Nothing to see here, move along\" > "
                ++ "/var/www/taranusaur.us/index.html"
            )
        , instructions
            [ text
                ("The nginx installation comes with a pre-configured site "
                    ++ "called "
                )
            , code "default"
            , text ".  Copy the config:"
            ]
        , codeBlock
            ("# cp /etc/nginx/sites-available/default "
                ++ "/etc/nginx/sites-available/taranusaur.us"
            )
        , instructions
            [ text "Set the "
            , code "root"
            , text " and "
            , code "server_name"
            , text " directives in the site configuration:"
            ]
        , codeFile "/etc/nginx/sites-available/taranusaur.us"
            [ "server {"
            , "    listen 80;"
            , "    listen [::]:80;"
            , ""
            , "    root /var/www/taranusaur.us;"
            , ""
            , "    index index.html index.htm index.nginx-debian.html;"
            , ""
            , "    server_name taranusaur.us www.taranusaur.us;"
            , ""
            , "    location / {"
            , "        try_files #uri #uri/ =404;"
            , "    }"
            , "}"
            ]
        , paragraph []
            [ text "The "
            , code "root"
            , text
                (" directive specifies where nginx will look for files to "
                    ++ "respond to requests with for the site.  The "
                )
            , code "server_name"
            , text
                (" directive should have the domains and subdomains  that are "
                    ++ "being served by this configuration."
                )
            ]
        , instructions [ text "Link the site config as an enabled site:" ]
        , codeBlock
            ("# ln -s /etc/nginx/sites-available/taranusaur.us "
                ++ "/etc/nginx/sites-enabled/"
            )
        , instructions [ text "Reload nginx:" ]
        , codeBlock "# systemctl reload nginx"
        , note
            (textColumn [ width fill, spacing 10 ]
                [ paragraph []
                    [ text
                        ("If nginx fails to reload, the problem can be "
                            ++ "debugged by checking the status of the "
                            ++ "service:"
                        )
                    ]
                , codeBlock "# systemctl status nginx"
                ]
            )
        ]


viewCreateCert : Element msg
viewCreateCert =
    textColumn [ width fill, spacing 15 ]
        [ viewHeading "Create TLS certificate"
        , instructions [ text "Run certbot:" ]
        , codeBlock "# certbot --nginx"
        , paragraph []
            [ text
                ("When prompted, enter an email address, agree to the terms, "
                    ++ "activate "
                )
            , code "https"
            , text
                (" for both names from the nginx config, and enable "
                    ++ "redirection from "
                )
            , code "http"
            , text " to "
            , code "https"
            , text "."
            ]
        , note
            (textColumn [ width fill, spacing 10 ]
                [ paragraph [] [ text "To renew the certificate, run:" ]
                , codeBlock "# certbot renew"
                ]
            )
        , instructions [ text "Reload nginx:" ]
        , codeBlock "# systemctl reload nginx"
        ]


code : String -> Element msg
code inner =
    el
        [ Background.color Page.colors.reallyLightBlue
        , paddingEach { edges | top = 4, bottom = 4, left = 5, right = 5 }
        , Font.family [ Font.monospace ]
        ]
        (text inner)


codeBlock : String -> Element msg
codeBlock inner =
    el
        [ Background.color Page.colors.reallyLightBlue
        , paddingEach { edges | top = 20, bottom = 20, left = 15, right = 15 }
        , Border.color Page.colors.lightgrey
        , Border.width 1
        , Font.family [ Font.monospace ]
        ]
        (text inner)


codeFile : String -> List String -> Element msg
codeFile file lines =
    column
        [ Background.color Page.colors.reallyLightBlue
        , Border.color Page.colors.lightgrey
        , Border.width 1
        , Font.family [ Font.monospace ]
        ]
        [ el
            [ Border.widthEach { edges | bottom = 1 }
            , Border.dashed
            , paddingEach
                { edges | top = 20, bottom = 20, left = 15, right = 15 }
            , Border.color Page.colors.lightgrey
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
