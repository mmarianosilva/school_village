import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { FormsModule } from "@angular/forms";
import { RouterModule } from '@angular/router';
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';
import { ButtonsModule } from 'ngx-bootstrap/buttons';

import { ButtonsComponent } from "./buttons.component";

const BUTTONS_COMPONENT_ROUTES = [
    { path: '', component: ButtonsComponent }
]

@NgModule ({
    declarations: [
        ButtonsComponent
    ],
    imports: [
        CommonModule,
        FormsModule,
        BsDropdownModule.forRoot(),
        ButtonsModule.forRoot(),
        RouterModule.forChild(BUTTONS_COMPONENT_ROUTES)
    ]
})

export class ButtonsComponentModule {  }