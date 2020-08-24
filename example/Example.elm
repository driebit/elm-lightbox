module Example exposing (main)

import Browser exposing (Document)
import Browser.Dom
import Browser.Events
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Lightbox
import Task exposing (Task)



-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MODEL


type alias Model =
    { lightbox : Maybe Lightbox.Config }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { lightbox = Nothing }
    , Cmd.none
    )



-- UPDATE


type Msg
    = ShowLightbox String String
    | HideLightbox
    | GotElement String (Result Browser.Dom.Error Browser.Dom.Element)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowLightbox id url ->
            ( model
            , Task.attempt (GotElement url) <|
                Browser.Dom.getElement id
            )

        HideLightbox ->
            ( { model | lightbox = Nothing }
            , Cmd.none
            )

        GotElement url (Ok element) ->
            ( { model | lightbox = Just { url = url, element = Just element } }
            , Cmd.none
            )

        GotElement url (Err _) ->
            ( { model | lightbox = Just { url = url, element = Nothing } }
            , Cmd.none
            )



-- VIEW


view : Model -> Document Msg
view model =
    { title = "elm-scroll-to"
    , body =
        [ case model.lightbox of
            Just config ->
                Lightbox.view { close = HideLightbox } config

            Nothing ->
                button
                    [ onClick (ShowLightbox "image" "esa-441508.jpg")
                    , style "background" "transparent"
                    , style "border" "0"
                    , style "padding" "0"
                    , style "margin" "10% auto"
                    , style "width" "10rem"
                    , style "display" "block"
                    ]
                    [ img
                        [ src "esa-441508.jpg"
                        , style "width" "10rem"
                        , id "image"
                        ]
                        []
                    , text "Photo: ESA"
                    ]
        ]
    }
