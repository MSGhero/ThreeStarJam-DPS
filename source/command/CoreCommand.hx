package command;

import command.Command;

enum CoreCommand {
	REGISTER(type:Command, callback:Command->Void);
}