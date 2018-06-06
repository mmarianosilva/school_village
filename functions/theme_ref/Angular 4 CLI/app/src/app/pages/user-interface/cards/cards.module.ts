import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from "@angular/router";
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

import { CardsComponent } from "./cards.component";

const COLORS_ROUTES = [
    { path: '', component: CardsComponent }
];

@NgModule ({
    declarations: [
        CardsComponent
    ],
    imports: [
        CommonModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(COLORS_ROUTES)
    ]
})

export class CardsModule {  }