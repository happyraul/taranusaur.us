module Page.Index exposing (Model, Msg, init, toSession, update, view)

import Element exposing (..)
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
    { top = 0, bottom = 0, left = 0, right = 0 }


view : Model -> { title : String, content : Element Msg }
view model =
    let
        link =
            viewLink model.activeLink
    in
    { title = "Perpetually Peregrine"
    , content =
        textColumn [ alignTop, spacing 20 ]
            [ paragraph [ Font.size 28, Font.bold ] [ text "News" ]
            , viewEntry "2020-07-27" <|
                paragraph []
                    [ text "Published "
                    , link "/setup-git" "git server guide"
                    , text "."
                    ]
            , viewEntry "2020-07-20" <|
                paragraph []
                    [ text "Published "
                    , link "/setup-vps" "VPS setup guide"
                    , text "."
                    ]
            , viewEntry "2019-09-13" <|
                paragraph []
                    [ text "Published "
                    , link "/directory" "directory"
                    , text "."
                    ]
            ]

    --column [ spacing 7 ]
    --    [ rootEntry "/" "about"
    --    , rootEntry "/books" "Books"
    --    , rootEntry "/coins" "Coins"
    --    , rootEntry "/cycling" "Cycling"
    --    , rootEntry "/directory" "Directory"
    --    , rootEntry "https://git.taranusaur.us/" "Git"
    --    , column [ spacing 7 ]
    --        [ text "Setup"
    --        , navEntry 1 "/setup-vps" "VPS & nginx"
    --        , navEntry 1 "/setup-git" "git server"
    --        ]
    --    --            , rootEntry "setup/" "Setup"
    --    , rootEntry "/video-games" "Video Games"
    --    , rootEntry "/vim" "Vim"
    --    ]
    }


viewEntry : String -> Element msg -> Element msg
viewEntry date entry =
    textColumn [ spacing 5 ]
        [ paragraph [ Font.bold, Font.size 24 ] [ text date ]
        , paragraph [] [ el [] entry ]
        ]


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
