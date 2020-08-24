module Lightbox exposing (Config, view)

import Browser.Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Svg
import Svg.Attributes as Attr



-- MODEL


type alias Config =
    { url : String
    , element : Maybe Browser.Dom.Element
    }


type alias Events msg =
    { close : msg
    }


view : Events msg -> Config -> Html msg
view { close } { url, element } =
    div
        [ id "elm-lightbox"
        , class "elm-lightbox"

        -- , preventDefaultOn "keydown" <|
        --     Decode.oneOf
        --         [ matchKey "Tab" ( ChangeFocus currentFocus, True )
        --         , matchKey "Escape" ( HideLightbox, True )
        -- ]
        ]
        [ img
            [ src url
            , id "elm-lightbox__image"
            , tabindex 0
            ]
            []
        , button
            [ class "elm-lightbox__close"
            , id "elm-lightbox__close"
            , onClick close
            ]
            [ viewClose
            , span [ class "visually-hidden" ] [ text "Sluit vertoning" ]
            ]
        , button
            -- [ onClick HideLightbox
            [ class "elm-lightbox__background"
            ]
            []
        , node "style"
            []
            [ text <|
                flipScaleInAnimation element
                    ++ styling
            ]
        ]


{-| <https://aerotwist.com/blog/flip-your-animations/>

Animation "technique" where you render the element in its final form
but add an animation that takes care of the transition from some orgin

-}
flipScaleInAnimation : Maybe Browser.Dom.Element -> String
flipScaleInAnimation maybeElement =
    case maybeElement of
        Nothing ->
            """
            @keyframes scaleImage {
                from {
                    opacity: 0;
                    transform: scale(0.8);
                }
                to {
                    opacity: 1;
                    transform: scale(1);
                }
            }
            """

        Just { element, viewport } ->
            let
                scale =
                    (/) 1 <|
                        Basics.min
                            (viewport.width / element.width)
                            (viewport.height * 0.8 / element.height)

                ( x, y ) =
                    ( element.width / 2 + element.x - viewport.x - viewport.width / 2
                    , element.height / 2 + element.y - viewport.y - viewport.height / 2
                    )
            in
            interpolate
                """
                @keyframes scaleImage {
                    from {
                        transform: translate({x}px, {y}px) scale({s});
                    }
                    to {
                        transform: translate(0,0) scale(1);
                    }
                }
                """
                [ ( "s", String.fromFloat scale )
                , ( "x", String.fromFloat x )
                , ( "y", String.fromFloat y )
                ]


interpolate : String -> List ( String, String ) -> String
interpolate =
    let
        f ( k, v ) acc =
            String.replace ("{" ++ k ++ "}") v acc
    in
    List.foldl f


matchKey : String -> msg -> Decode.Decoder msg
matchKey key_ msg =
    Decode.field "key" Decode.string
        |> Decode.andThen
            (\s ->
                if key_ == s then
                    Decode.succeed msg

                else
                    Decode.fail "Not an match"
            )


viewClose : Svg.Svg msg
viewClose =
    Svg.svg [ Attr.viewBox "0 0 24 24" ]
        [ Svg.path
            [ Attr.d "M12 10.6L6.6 5.2 5.2 6.6l5.4 5.4-5.4 5.4 1.4 1.4 5.4-5.4 5.4 5.4 1.4-1.4-5.4-5.4 5.4-5.4-1.4-1.4-5.4 5.4z"
            ]
            []
        ]


viewZoom : Svg.Svg msg
viewZoom =
    Svg.svg [ Attr.viewBox "0 0 24 24" ]
        [ Svg.path
            [ Attr.d "M18.7 17.3l-3-3a5.9 5.9 0 0 0-.6-7.6 5.9 5.9 0 0 0-8.4 0 5.9 5.9 0 0 0 0 8.4 5.9 5.9 0 0 0 7.7.7l3 3a1 1 0 0 0 1.3 0c.4-.5.4-1 0-1.5zM8.1 13.8a4 4 0 0 1 0-5.7 4 4 0 0 1 5.7 0 4 4 0 0 1 0 5.7 4 4 0 0 1-5.7 0z"
            ]
            []
        ]


styling : String
styling =
    """
body {
    height:100%;
    overflow:hidden;
}
.elm-lightbox {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    position: fixed;
    top: 0;
    left: 0;
    z-index: 1;
}
.elm-lightbox img {
   max-width: 100%;
   max-height: 80%;
   position: relative;
   z-index: 1;
   animation: scaleImage .5s forwards;
}
.elm-lightbox svg {
   fill: #999;
}
.elm-lightbox__background {
    width: 100%;
    height: 100%;
    opacity: 0;
    position: absolute;
    top: 0;
    left: 0;
    background: rgba(0,0,0,0.8);
    z-index: -1;
    animation: elm-lightbox-appear .5s .15s forwards;
}
.elm-lightbox__close {
    width: 2.5rem;
    height: 2.5rem;
    padding: .5rem;
    position: absolute;
    top: 0;
    right: 0;
    background: #222;
    transition: background-color .25s;
}
@keyframes elm-lightbox-appear {
    from {opacity: 0;}
    to {opacity: 1;}
}
"""
