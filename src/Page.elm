module Page exposing (Page(..), colors, view)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import FontAwesome.Styles as Icon


type Page
    = Index
    | Directory
    | Setup
    | Vim



-- VIEW


edges =
    { top = 0, right = 0, bottom = 0, left = 0 }


colors =
    { primary = rgb 0.2 0.72 0.91
    , success = rgb 0.275 0.533 0.278 -- #468847
    , info = rgb 0.227 0.529 0.678 -- #3a87ad
    , important = rgb 0.729 0.29 0.282 -- #b94a48
    , warning = rgb 0.8 0.2 0.2
    , link = rgb 0.361 0.502 0.737
    , black = rgb 0.067 0.067 0.067
    , darkgrey = rgb 0.31 0.31 0.31
    , lightgrey = rgb 0.733 0.733 0.733
    , pink = rgb 1.0 0.455 0.549
    , tan = rgb 0.824 0.706 0.549
    , reallyLightBlue = rgb 0.91 0.99 0.99
    , reallyLightPink = rgb 0.99 0.95 0.99
    , lilac = rgb 0.808 0.635 0.992 -- #cea2fd
    , lightViolet = rgb 0.839 0.706 0.988 -- #d6b4fc
    , lightLavender = rgb 0.875 0.773 0.996 -- #dfc5fe
    , paleLavender = rgb 0.933 0.812 0.996 -- #eecffe

    --, white = rgb 0.99 0.99 0.99
    , white = rgb 0.99 0.99 0.973
    , snow = rgb 1 0.98 0.98
    }


view :
    { title : String, content : Element subMsg }
    -> (subMsg -> msg)
    -> Browser.Document msg
view { title, content } toSubMsg =
    Browser.Document ("Taranusaurus | " ++ title)
        [ Icon.css
        , layout
            [ Font.color colors.black
            , Font.family [ Font.typeface "Georgia", Font.serif ]
            , Background.color <| rgb 0.99 0.99 0.99
            ]
          <|
            row [ height fill, width fill ]
                [ column
                    [ width (fill |> maximum 1600)
                    , Background.color colors.white
                    , paddingEach
                        { edges
                            | top = 20
                            , left = 30
                            , right = 30
                            , bottom = 20
                        }
                    , alignTop
                    , centerX
                    ]
                    [ paragraph
                        [ Font.size 48
                        , Font.heavy
                        , paddingEach { edges | bottom = 20 }
                        ]
                        [ link [] { url = "/", label = text "Taranusaurus" }
                        , text (" |> " ++ title)
                        ]
                    , map toSubMsg content
                    ]
                ]
        ]
