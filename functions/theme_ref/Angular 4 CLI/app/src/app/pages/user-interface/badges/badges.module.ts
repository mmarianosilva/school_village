import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from "@angular/router";
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

import { BadgesComponent } from "./badges.component";

const BADGES_ROUTES = [
    { path: '', component: BadgesComponent }
];

@NgModule ({
    declarations: [
        BadgesComponent
    ],
    imports: [
        CommonModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(BADGES_ROUTES)
    ]
})

export class BadgesModule {  }