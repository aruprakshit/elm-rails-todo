module Page.NotFound exposing (view)

import Html exposing (Html, a, div, h1, h2, p, text)
import Html.Attributes exposing (class, href, id)


view =
    div [ id "notfound" ]
        [ div [ class "notfound" ]
            [ div [ class "notfound-404" ]
                [ h1 [] [ text "404" ]
                ]
            , h2 [] [ text "Oops! This Page Could Not Be Found" ]
            , p []
                [ text "Sorry but the page you are looking for does not exist, have been removed. name changed or is temporarily unavailable" ]
            , a [ href "/" ] [ text "Go To Homepage" ]
            ]
        ]
