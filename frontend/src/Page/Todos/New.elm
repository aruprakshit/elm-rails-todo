module Page.Todos.New exposing (view)

import Html exposing (Html, a, div, form, input, label, text, textarea)
import Html.Attributes exposing (href, placeholder, style, type_)


view : Html msg
view =
    div []
        [ form []
            [ div [ style "margin-bottom" "10px" ]
                [ label []
                    [ text "Title:"
                    , input [ type_ "text", placeholder "Title", style "margin-left" "10px" ] []
                    ]
                ]
            , div [ style "margin-bottom" "10px" ]
                [ label []
                    [ text "Content:"
                    , textarea [ placeholder "Content", style "margin-left" "10px" ] []
                    ]
                ]
            ]
        , a [ href "/" ] [ text "Back" ]
        ]
