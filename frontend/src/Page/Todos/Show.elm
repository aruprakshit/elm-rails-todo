module Page.Todos.Show exposing (view)

import Html exposing (Html, a, button, div, form, input, label, text, textarea)
import Http
import Page.Home exposing (Todo)


type alias Model =
    Todo


view msg model =
    text "Ongoing"
