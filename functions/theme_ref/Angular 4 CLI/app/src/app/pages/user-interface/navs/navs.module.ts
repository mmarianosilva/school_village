import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from "@angular/router";
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

import { NavsComponent } from "./navs.component";

const NAVS_ROUTES = [
    { path: '', component: NavsComponent }
];

@NgModule ({
    declarations: [
        NavsComponent
    ],
    imports: [
        CommonModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(NAVS_ROUTES)
    ]
})

export class NavsModule {  }