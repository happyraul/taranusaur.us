module Main exposing (init)

import Browser
import Browser.Navigation as Navigation
import Element exposing (..)
import Json.Decode as Decode
import Page
import Page.Directory as Directory
import Page.Index as Index
import Page.Setup.Git as SetupGit
import Page.Setup.Vps as SetupVps
import Route
import Session
import Task
import Url


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        }



-- Model


type Model
    = Directory Directory.Model
    | Index Index.Model
    | SetupVps SetupVps.Model
    | SetupGit SetupGit.Model


init : () -> Url.Url -> Navigation.Key -> ( Model, Cmd Msg )
init () url key =
    let
        session =
            Session.fromKey key
    in
    changeRouteTo (Route.fromUrl url) (Index <| Index.init session)



-- UPDATE


type Msg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | GotDirectoryMsg Directory.Msg
    | GotIndexMsg Index.Msg
    | GotSetupVpsMsg SetupVps.Msg
    | GotSetupGitMsg SetupGit.Msg


toSession : Model -> Session.Session
toSession page =
    case page of
        Index index ->
            Index.toSession index

        Directory directory ->
            Directory.toSession directory

        SetupVps setup ->
            SetupVps.toSession setup

        SetupGit setup ->
            SetupGit.toSession setup


changeRouteTo : Maybe Route.Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( model, Cmd.none )

        Just Route.Index ->
            ( Index <| Index.init session, Cmd.none )

        Just (Route.Directory maybeSection) ->
            Directory.init session maybeSection
                |> updateWith Directory GotDirectoryMsg

        Just Route.SetupVps ->
            ( SetupVps <| SetupVps.init session, Cmd.none )

        Just Route.SetupGit ->
            ( SetupGit <| SetupGit.init session, Cmd.none )

        Just Route.Vim ->
            ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Navigation.pushUrl (Session.navKey <| toSession model)
                        (Url.toString url)
                    )

                Browser.External href ->
                    ( model, Navigation.load href )

        ( GotDirectoryMsg subMsg, Directory directory ) ->
            ( Directory <| Directory.update subMsg directory, Cmd.none )

        ( GotIndexMsg subMsg, Index index ) ->
            ( Index <| Index.update subMsg index, Cmd.none )

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page
            ( model, Cmd.none )


updateWith :
    (subModel -> Model)
    -> (subMsg -> Msg)
    -> ( subModel, Cmd subMsg )
    -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel, Cmd.map toMsg subCmd )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        viewPage :
            (msg -> Msg)
            -> { title : String, content : Element msg }
            -> Browser.Document Msg
        viewPage toMsg config =
            Page.view config toMsg
    in
    case model of
        Index index ->
            Index.view index
                |> viewPage GotIndexMsg

        Directory directory ->
            Directory.view directory
                |> viewPage GotDirectoryMsg

        SetupVps setup ->
            SetupVps.view setup
                |> viewPage GotSetupVpsMsg

        SetupGit setup ->
            SetupGit.view setup
                |> viewPage GotSetupGitMsg



-- Subscriptions


subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none
