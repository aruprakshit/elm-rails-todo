module Navigation exposing (AuthenticatedRoute(..), Route(..), UnAuthenticatedRoute(..), toRoute)

import Url exposing (Url)
import Url.Parser exposing (..)


type UnAuthenticatedRoute
    = Signup
    | Signin


type AuthenticatedRoute
    = New
    | Edit Int
    | Index
    | Show Int


type Route
    = UnAuthed UnAuthenticatedRoute
    | Authed AuthenticatedRoute
    | NotFound


route : Parser (Route -> a) a
route =
    let
        toEditRoute todoId =
            Authed (Edit todoId)

        toShowRoute todoId =
            Authed (Show todoId)
    in
    oneOf
        [ map (Authed Index) top
        , map (Authed New) (s "todos" </> s "new")
        , map toEditRoute (s "todos" </> int </> s "edit")
        , map toShowRoute (s "todos" </> int)
        , map (UnAuthed Signin) (s "sign-in")
        , map (UnAuthed Signup) (s "sign-up")
        ]


toRoute : String -> Route
toRoute url =
    case Url.fromString url of
        Nothing ->
            NotFound

        Just uri ->
            Maybe.withDefault NotFound (parse route uri)
