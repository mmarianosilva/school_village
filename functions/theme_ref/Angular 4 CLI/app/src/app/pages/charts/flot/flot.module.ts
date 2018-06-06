import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';
import { SharedModule } from "../../../shared/shared.module";

import { FlotComponent } from "./flot.component";

const FLOT_ROUTE = [
    { path: '', component: FlotComponent }
];

@NgModule ({
    declarations: [
        FlotComponent
    ],
    imports: [
        CommonModule,
        SharedModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(FLOT_ROUTE)
    ]
})

export class FlotModule {  }