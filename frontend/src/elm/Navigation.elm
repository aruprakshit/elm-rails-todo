module Navigation exposing (Route(..), toRoute)

import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = New
    | Edit Int
    | Index
    | Show Int
    | NotFound
    | Login


route : Parser (Route -> a) a
route =
    oneOf
        [ map Index top
        , map New (s "todos" </> s "new")
        , map Edit (s "todos" </> int </> s "edit")
        , map Show (s "todos" </> int)
        , map Login (s "sign-in")
        ]


toRoute : String -> Route
toRoute url =
    case Url.fromString url of
        Nothing ->
            NotFound

        Just uri ->
            Maybe.withDefault NotFound (parse route uri)
