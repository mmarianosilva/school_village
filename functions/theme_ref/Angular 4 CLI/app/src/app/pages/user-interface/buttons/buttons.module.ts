import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from "@angular/router";
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

import { ButtonsComponent } from "./buttons.component";

const BUTTONS_ROUTES = [
    { path: '', component: ButtonsComponent }
];

@NgModule ({
    declarations: [
        ButtonsComponent
    ],
    imports: [
        CommonModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(BUTTONS_ROUTES)
    ]
})

export class ButtonsModule {  }