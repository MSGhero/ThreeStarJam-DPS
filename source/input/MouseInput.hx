package input;

import hxd.Key;
import haxe.ds.Vector;
import input.Input.InputMapping;

class MouseInput extends InputDevice {
     
     public function new(mappings:InputMapping, isComplex:Vector<Bool> = null) {
          super("mouse", mappings, isComplex);
     }
     
     function isButtonDown(buttonCode:Int) {
          return Key.isDown(buttonCode);
     }
}