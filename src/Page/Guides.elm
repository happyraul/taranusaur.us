module Page.Guides exposing (Model, init, toSession, view)

import Element exposing (..)
import Element.Font as Font
import Session



-- MODEL


type alias Model =
    { activeLink : Maybe String
    , session : Session.Session
    }


init : Session.Session -> Model
init session =
    Model Nothing session



-- VIEW


view : Model -> { title : String, content : Element msg }
view model =
    { title = "Guides"
    , content =
        textColumn [ alignTop, spacing 20 ]
            [ paragraph [ Font.size 28, Font.bold ] [ text "Guides" ]
            , paragraph []
                [ text <|
                    "Documentation for setting up this VPS, and other guides "
                        ++ "besides."
                ]
            ]
    }



-- EXPORT


toSession : Model -> Session.Session
toSession model =
    model.session
