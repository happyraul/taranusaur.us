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
        navEntry level =
            viewLink level model.activeLink

        rootEntry =
            navEntry 0
    in
    { title = "Perpetually Peregrine"
    , content =
        column [ spacing 7 ]
            [ rootEntry "/books" "Books"
            , rootEntry "/coins" "Coins"
            , rootEntry "/cycling" "Cycling"
            , rootEntry "/directory" "Directory"
            , rootEntry "https://git.taranusaur.us/" "Git"
            , column [ spacing 7 ]
                [ text "Setup"
                , navEntry 1 "/setup-vps" "VPS & nginx"
                , navEntry 1 "/setup-git" "git server"
                ]

            --            , rootEntry "setup/" "Setup"
            , rootEntry "/video-games" "Video Games"
            , rootEntry "/vim" "Vim"
            ]
    }


viewLink : Int -> Maybe String -> String -> String -> Element Msg
viewLink level activeLink url page =
    let
        baseAttributes =
            [ Font.color Page.colors.link
            , Events.onMouseEnter (HoveredLink page)
            , Events.onMouseLeave UnHoveredLink
            , paddingEach { edges | left = 40 * level }
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
