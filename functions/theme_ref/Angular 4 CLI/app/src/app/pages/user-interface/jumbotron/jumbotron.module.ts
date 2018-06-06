import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from "@angular/router";
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

import { JumbotronComponent } from "./jumbotron.component";

const JUMBOTRON_ROUTES = [
    { path: '', component: JumbotronComponent }
];

@NgModule ({
    declarations: [
        JumbotronComponent
    ],
    imports: [
        CommonModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(JUMBOTRON_ROUTES)
    ]
})

export class JumbotronModule {  }