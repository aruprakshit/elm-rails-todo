module Page.Todos.Show exposing (view)

import Html exposing (Html, a, button, div, form, input, label, text, textarea)
import Http
import Page.Home exposing (Todo)


type alias Model =
    Maybe Todo


view model =
    let
        content =
            case model of
                Just todo ->
                    todo.title

                Nothing ->
                    "Loading"
    in
    text content
