module Session exposing (Session, fromKey, navKey)

import Browser.Navigation as Navigation


type Session
    = Session Navigation.Key


navKey : Session -> Navigation.Key
navKey (Session key) =
    key


fromKey : Navigation.Key -> Session
fromKey key =
    Session key
