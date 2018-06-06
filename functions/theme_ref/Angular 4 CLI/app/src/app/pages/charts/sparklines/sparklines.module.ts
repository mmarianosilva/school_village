import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';
import { SharedModule } from "../../../shared/shared.module";

import { SparklinesComponent } from "./sparklines.component";

const SPARKLINES_ROUTE = [
    { path: '', component: SparklinesComponent }
];

@NgModule ({
    declarations: [
        SparklinesComponent
    ],
    imports: [
        CommonModule,
        SharedModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(SPARKLINES_ROUTE)
    ]
})

export class SparklineModule {  }