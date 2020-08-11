module Page.Setup exposing (Model, Msg, init, toSession, update, view)

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
    { title = "Setup"
    , content =
        textColumn [ spacing 15, width fill ]
            [ paragraph []
                [ text
                    "These instructions are for setting up this server on a "
                , link [ Font.color Page.colors.link ]
                    { url = "https://www.vultr.com/"
                    , label = text "Vultr"
                    }
                , text " VPS instance."
                ]
            , viewHeading "Deploy new instance"
            , paragraph [ paddingEach { edges | top = 20 } ]
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
            , paragraph [ paddingEach { edges | top = 20 } ]
                [ text "2. Select the "
                , code "New York (NJ)"
                , text " location:"
                ]
            , image []
                { src = "/static/img/server-location.png"
                , description = "Server Location"
                }
            , paragraph [ paddingEach { edges | top = 20 } ]
                [ text "3. Select "
                , code "Debian 10 x64"
                , text " for the OS:"
                ]
            , image []
                { src = "/static/img/server-type.png"
                , description = "Server Type"
                }
            , paragraph [ paddingEach { edges | top = 20 } ]
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
            , paragraph [ paddingEach { edges | top = 20 } ]
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
            , paragraph [ paddingEach { edges | top = 20 } ]
                [ text "6. Enter a hostname and click "
                , code "Deploy Now"
                , text "."
                ]
            , viewHeading "Configure DNS"
            , paragraph [ paddingEach { edges | top = 20 } ]
                [ text
                    ("Once the server is up and running, find its IP "
                        ++ "addresses (both"
                    )
                , code "IPv4"
                , text " and "
                , code "IPv6"
                , text ")."
                ]
            , paragraph [ paddingEach { edges | top = 10 } ]
                [ text
                    ("1. Using the DNS management for your nameserver, "
                        ++ "create an "
                    )
                , code "A"
                , text " record from your domain name to the "
                , code "IPv4"
                , text " address."
                ]
            , paragraph []
                [ text "2. Create a "
                , code "AAAA"
                , text " record from your domain name to the "
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
            , viewHeading "Configure SSH"
            , viewHeading "Install packages"
            , viewHeading "Configure nginx"
            , viewHeading "Create TLS certificate"
            ]
    }


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


code : String -> Element msg
code inner =
    el
        [ Background.color Page.colors.reallyLightBlue
        , padding 5
        , Border.color Page.colors.lightgrey
        , Border.width 1
        , Font.family [ Font.monospace ]
        ]
        (text inner)


viewHeading : String -> Element msg
viewHeading heading =
    el
        [ Font.size 28
        , Font.heavy
        , paddingEach { edges | top = 15 }
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
