module Navigation exposing (Route(..), toRoute)

import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = New
    | Edit Int
    | Index
    | Show Int
    | NotFound


route : Parser (Route -> a) a
route =
    oneOf
        [ map Index top
        , map New (s "todos" </> s "new")
        , map Edit (s "todos" </> s "edit" </> int)
        , map Show (s "todos" </> s "show" </> int)
        ]


toRoute : String -> Route
toRoute url =
    case Url.fromString (Debug.log "URl" url) of
        Nothing ->
            NotFound

        Just uri ->
            Maybe.withDefault NotFound (parse route uri)
