# DM Manager

## Introduccion

Es una aplicacion movil desarrollada en Flutter que permite realizar la gestion de empleados, cotizaciones de servicios y pago de liquidaciones a empleados de forma optima.

Esta dirigida a empresas de construccion cuyo objectivo es organizar el proceso de cotizacion de prestacion de servicios de manera rapida y conciza.

| Modulo de empleados                                               | Modulo de cotizaciones                                                  | Modulo de pagos de liquidaciones                                    |
| ----------------------------------------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------- |
| <img src="./screenshots/EmployeeScrollAnimation.gif" width="300"> | <img src="./screenshots/CotizationPerspectiveListView.gif" width="300"> | <img src="./screenshots/PayLiquidationAnimations.gif" width="300" > |

## Es Multiplataforma

La aplicacion esta optimizada para trabajar en los sistemas operativos moviles mas usados de la actualidad (Android y IOS).

Esto permite tener un alcance de usuarios mucho mayor, eliminando la barrera de compatibilidad.

## Instrucciones para instalacion

### Requisitos

1. Android SDK
2. Flutter SDK
3. Telefono Movil Android

### Pasos

1. Entramos a la carpeta raiz del proyecto y ejecutamos:

`flutter pub get`

Luego:

`flutter build apk`

2. Conectamos el dispositivo android al PC con la depuracion usb activada.

_Nota: Si no sabe como activar la depuracion usb de su dispositivo, de click [aqui](https://devexperto.com/como-activar-la-depuracion-usb/) para ver un tutorial sobre como activarla._

Ejecutamos el siguiente comando:

`adb install build/app/outputs/apk/release/app-release.apk`

Aceptamos cualquier solicitud que nos pida en el momento de la instalacion y con esto ya estaria la app disponible en su dispositivos android.
