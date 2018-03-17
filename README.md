# An attempt at an Apex Logger Service for the Salesforce's Lightning Platform

Leverages Platform Events to store Log information and uses `AppConfig*` Classes to control behaviour thereof. Automatically detects current class and method name as well as current line and column.

## Screenshots
[![DebugEntry Record View](https://i.imgur.com/00yymeb.png)](https://i.imgur.com/00yymeb.png)

[![Developer Console](https://i.imgur.com/PRtY1R6.png)](https://i.imgur.com/PRtY1R6.png)

## Usage Example

```java
/*
*   EXAMPLE CLASS FOR LOGGER
*/

public with sharing class Handler {
    public Handler() {
        Logger.push();
        routine1();
        routine2();
        Logger.pop();
    }

    public void routine1(){
        Logger.push();
        Logger.log('entering subroutine1');
        subroutine1();
        Logger.pop();
    }

    public void routine2(){
        Logger.push();
        subroutine2();
        Logger.pop();
    }

    public void subroutine1(){
        Logger.push();
        Logger.pop();
    }

    public void subroutine2(){
        Logger.push();
        subsub1();
        subsub2();
        Logger.pop();
    }

    public void subsub1(){
        Logger.push();
        Logger.log('doing complex stuff');
        subsub2();
        Logger.pop();
    }

    public void subsub2(){
        Logger.push();
        Logger.log('Doing stuff at stacktrace: ' + Logger.stackTrace);
        Logger.pop();
    }
}
```

## Kudos
[Dan Appleman](https://twitter.com/danappleman) and [Adrian Larsson](https://twitter.com/ApexLarson)

