module Page.Todos.New exposing (view)

import Html exposing (Html, form, input, text)
import Html.Attributes exposing (placeholder, type_)


view : Html msg
view =
    form []
        [ input [ type_ "text", placeholder "Title" ] []
        ]
