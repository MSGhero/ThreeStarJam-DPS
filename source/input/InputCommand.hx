package input;

import input.InputID;

enum InputCommand {
     ADD_INPUT(mapping:Input, tag:InputID);
     ENABLE_INPUT(tag:InputID);
     DISABLE_INPUT(tag:InputID);
}