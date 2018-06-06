import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { TodoListsComponent } from "./todo-lists.component";


@NgModule ({
    declarations: [
        TodoListsComponent
    ],
    imports: [
        CommonModule
    ]
})

export class TodoListsModule {  }