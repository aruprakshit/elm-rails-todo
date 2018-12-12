module Main exposing (main)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html, a, div, h1, text)
import Html.Attributes exposing (href)
import Http
import Json.Decode as JD
import Navigation exposing (Route(..), toRoute)
import Page.Home as Home exposing (Todo, initialTodo)
import Page.Todos.New as NewTodoPage
import Url exposing (Url)



-- MODEL


type alias Model =
    { key : Nav.Key
    , state : State
    }


type State
    = NewTodo Todo
    | EditTodo Todo
    | Home (List Todo)
    | ShowTodo Todo



-- UPDATE


type Msg
    = ChangedUrl Url
    | ActivatedLink Browser.UrlRequest
    | GotTodos (Result Http.Error (List Todo))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ActivatedLink urlContainer ->
            case urlContainer of
                Internal url ->
                    ( model, Nav.pushUrl model.key url.path )

                External path ->
                    ( model, Cmd.none )

        ChangedUrl url ->
            case toRoute <| Url.toString url of
                Index ->
                    ( model
                    , fetchTodos
                    )

                New ->
                    ( { model | state = NewTodo initialTodo }
                    , Cmd.none
                    )

                Show todoId ->
                    ( model
                    , Cmd.none
                    )

                Edit todoId ->
                    ( model
                    , Cmd.none
                    )

                NotFound ->
                    ( model
                    , Cmd.none
                    )

        GotTodos response ->
            case response of
                Ok todos ->
                    ( { model | state = Home todos }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- INIT


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    ( { key = navKey, state = Home [] }, fetchTodos )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


pageTitle : State -> String
pageTitle state =
    case state of
        Home _ ->
            "Home Page"

        NewTodo _ ->
            "Create a todo item"

        _ ->
            ""


pageBody : Model -> Html Msg
pageBody { key, state } =
    let
        body =
            case state of
                Home todos ->
                    Home.view todos

                NewTodo todo ->
                    NewTodoPage.view

                _ ->
                    text "Not ready yet"
    in
    div []
        [ h1 [] [ text <| pageTitle state ]
        , body
        ]


view : Model -> Document Msg
view model =
    { title = pageTitle model.state
    , body =
        [ pageBody model
        , a [ href "todos/new" ] [ text "Create Todo" ]
        ]
    }



-- MAIN


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = ChangedUrl
        , onUrlRequest = ActivatedLink
        }


fetchTodos : Cmd Msg
fetchTodos =
    Http.get
        { url = "http://localhost:3000/todos"
        , expect = Http.expectJson GotTodos responseDecoder
        }


responseDecoder : JD.Decoder (List Todo)
responseDecoder =
    JD.list todoDecoder


todoDecoder : JD.Decoder Todo
todoDecoder =
    JD.map4 Todo
        (JD.field "title" JD.string)
        (JD.field "content" JD.string |> JD.maybe)
        (JD.field "completed" JD.bool)
        (JD.field "id" JD.int |> JD.maybe)
