module Page.Todos.New exposing (Msg(..), update, view)

import Browser.Navigation as Nav
import Config exposing (AuthState(..), backendDomain)
import Decoders.Todos exposing (todoDecoder)
import Entities.Todo as Todo
import Html exposing (Html, a, button, div, form, h1, input, label, text, textarea)
import Html.Attributes exposing (class, href, placeholder, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import Json.Encode as JE
import Url.Builder as UB


type Msg
    = OnInputChange String String
    | CreateTodo
    | CreatedTodo (Result Http.Error Model)


type alias Model =
    Todo.Model


update : Config.Model -> Msg -> Model -> ( Model, Cmd Msg )
update config msg model =
    case msg of
        OnInputChange "title" value ->
            ( { model | title = value }, Cmd.none )

        OnInputChange "content" value ->
            ( { model | content = Just value }, Cmd.none )

        OnInputChange _ _ ->
            ( model, Cmd.none )

        CreateTodo ->
            ( model, createTodo config model )

        CreatedTodo response ->
            ( model, Nav.pushUrl config.key "/" )


view : Model -> List (Html Msg)
view model =
    [ div [ class "row" ]
        [ div [ class "col-12" ]
            [ h1 [] [ text "Create a new todo" ]
            , form
                [ onSubmit CreateTodo ]
                [ div [ class "form-group" ]
                    [ label [] [ text "Title:" ]
                    , input
                        [ type_ "text"
                        , placeholder "Title"
                        , class "form-control col-4"
                        , value model.title
                        , onInput (OnInputChange "title")
                        ]
                        []
                    ]
                , div [ class "form-group" ]
                    [ label [] [ text "Content:" ]
                    , textarea
                        [ placeholder "Content"
                        , class "form-control"
                        , value (Maybe.withDefault "" model.content)
                        , onInput (OnInputChange "content")
                        ]
                        []
                    ]
                , div []
                    [ button [ class "btn btn-primary" ] [ text "Save" ]
                    ]
                ]
            ]
        ]
    , div [ class "card mt-4" ]
        [ div [ class "card-body d-flex" ]
            [ a [ href "/", class "btn btn-primary" ] [ text "Back home" ]
            ]
        ]
    ]


createTodo : Config.Model -> Model -> Cmd Msg
createTodo config formData =
    let
        authToken =
            case config.token of
                Authenticated token ->
                    token

                NotAuthenticated ->
                    ""
    in
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Authorization" authToken
            ]
        , url = backendDomain ++ UB.absolute [ "todos" ] []
        , body = Http.jsonBody <| todoPayload formData
        , expect = Http.expectJson CreatedTodo todoDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


todoPayload : Model -> JE.Value
todoPayload formData =
    JE.object
        [ ( "title", JE.string formData.title )
        , ( "content", JE.string (Maybe.withDefault "" formData.content) )
        , ( "completed", JE.bool formData.completed )
        ]
