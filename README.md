# M.I.Suggestion
The final project of 2018 mobile programming class. (iOS)

## Members
- R06922047 林進源
- B03902097 彭奕豪
- B04902079 甯芝蓶

## Runtime Requirements

- Swift 4.0
- Xcode 9.2
- iOS9.0 or later

## Installing with CocoaPods

[CocoaPods](http://cocoapods.org) is a centralised dependency manager that automates the process of adding libraries to your Cocoa application. You can install it with the following command:

```bash
$ gem update
$ gem install cocoapods
$ pods --version
```

To run this project, specify the follwoing library in your `Podfile` and run `pod install`.
```
  pod 'TouchVisualizer'
  pod 'Firebase/Core'
  pod 'Firebase/Storage'
```

## Introduction
Motor impaired people are often unable to use touch screen as smoothly as we do. They often encounter several problems, such as multiple concurrent touches, inaccurate landing and lifting behavior (slow movement,sliding finger) and so on.
For these users, iOS provide a solution: the Touch Accommodations settings.

Touch Accommodations includes 3 features: If you want your device to respond only to touches of a certain duration, adjust `Hold Durations`. If you want your device to ignore multiple touches, turn on `Ignore Repeat`. `Tap Assistance` could be useful if you want your device to respond to the first or the last place you touch.
But... HOW should M.I. users adjust these arguments? 

M.I. Suggestion use gamified tasks to collect users’ touching behaviour. There are three categories of tasks: Tapping, Dragging, and Swiping. We collected different kinds of touch data during each task, including touches positions, timestamps, area and so on. These touch data are then sent to Firebase to build a personal model. With this personal model, we could calculate the optimal touch accommodation arguments for users. Users can freely decided whether they would like to adjust the argument based on our suggestion on the main page.
During the game, user could find the suitable arguments by pushing the envelope and meanwhile having lots of fun.

## Detail info
See [our poster](https://github.com/Oliveck10/MISuggestion_game/blob/master/poster.pdf)