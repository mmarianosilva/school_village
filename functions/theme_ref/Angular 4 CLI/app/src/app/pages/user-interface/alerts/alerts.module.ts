import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from "@angular/router";
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

import { AlertsComponent } from "./alerts.component";

const ALERTS_ROUTES = [
    { path: '', component: AlertsComponent }
];

@NgModule ({
    declarations: [
        AlertsComponent
    ],
    imports: [
        CommonModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(ALERTS_ROUTES)
    ]
})

export class AlertsModule {  }