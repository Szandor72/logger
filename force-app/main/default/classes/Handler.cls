/*
*   EXAMPLE CLASS FOR LOGGER
*/

public with sharing class Handler {
    public Handler() {
        Logger.push();
        Logger.log('Constructor');
        routine1();
        routine2();
        Logger.log('Constructor finished');
        Logger.pop();
    }

    public void method1Exception() {
        Logger.push();
        raiseException();
        Logger.pop();
    }

    public void raiseException() {
        Logger.push();
        try {
            throw new DmlException();
        } catch (exception ex) {
            Logger.logException(ex);
            Logger.popAll();
        }
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
        Logger.log('Doing stuff at stacktrage: ' + Logger.stackTrace);
        Logger.pop();
    }
}