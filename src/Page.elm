module Page exposing (Page, colors, pages, view)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import FontAwesome.Styles as Icon



-- MODEL


type alias Page =
    { target : String
    , anchor : String
    }


type Navigation
    = Navigation (List Entry)


type Entry
    = Section Page (List Entry)
    | Entry Page


navMenu =
    Navigation
        [ Entry pages.index
        , Entry pages.directory
        , Section pages.guides
            [ Entry pages.setupVps
            , Entry pages.setupGit
            ]
        ]


pages =
    { index = Page "/" "about"
    , directory = Page "/directory" "directory/"
    , guides = Page "/guides" "guides/"
    , setupVps = Page "/setup-vps" "vps/"
    , setupGit = Page "/setup-git" "git/"
    }



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
    , lightgrey = rgb 0.733 0.733 0.733
    , pink = rgb 1.0 0.455 0.549
    , tan = rgb 0.824 0.706 0.549
    , reallyLightBlue = rgb 0.91 0.99 0.99
    , reallyLightPink = rgb 0.99 0.95 0.99
    , greyBlue = rgb 0.42 0.545 0.643 -- #6b8ba4
    , darkGrey = rgb 0.212 0.212 0.216 -- #363737
    , lilac = rgb 0.808 0.635 0.992 -- #cea2fd
    , lightViolet = rgb 0.839 0.706 0.988 -- #d6b4fc
    , lightLavender = rgb 0.875 0.773 0.996 -- #dfc5fe
    , paleLavender = rgb 0.933 0.812 0.996 -- #eecffe

    --, white = rgb 0.99 0.99 0.99
    , white = rgb 0.99 0.99 0.973
    , snow = rgb 1 0.98 0.98
    }


view :
    Page
    -> { title : String, content : Element subMsg }
    -> (subMsg -> msg)
    -> Browser.Document msg
view page { title, content } toSubMsg =
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
                    , row [ spacing 20 ]
                        [ viewNavigation page.target
                        , map toSubMsg content
                        ]
                    ]
                ]
        ]


viewNavigation : String -> Element msg
viewNavigation current =
    let
        entries =
            case navMenu of
                Navigation navEntries ->
                    navEntries

        navEntry =
            viewSection 0 current
    in
    column
        [ alignTop
        , spacing 7
        , Border.widthEach { edges | right = 1 }
        , Border.color colors.darkGrey
        , paddingEach { edges | right = 60 }
        ]
        (List.map navEntry entries)


viewSection : Int -> String -> Entry -> Element msg
viewSection level current navEntry =
    let
        entryUrl e =
            case e of
                Entry entry ->
                    entry.target

                Section entry _ ->
                    entry.target
    in
    case navEntry of
        Entry entry ->
            viewLink level current entry

        Section entry entries ->
            if
                current
                    == entry.target
                    || List.member current (List.map entryUrl entries)
            then
                column [ spacing 7 ]
                    (viewLink level current entry
                        :: List.map (viewSection (level + 1) current) entries
                    )

            else
                viewLink level current entry


viewLink : Int -> String -> Page -> Element msg
viewLink level current page =
    let
        baseAttributes =
            [ Font.color colors.link

            --, Events.onMouseEnter (HoveredLink page)
            --, Events.onMouseLeave UnHoveredLink
            , paddingEach { edges | left = 20 * level }
            ]

        attributes =
            if current == page.target then
                Font.bold :: baseAttributes

            else
                baseAttributes
    in
    link attributes { url = page.target, label = text page.anchor }
