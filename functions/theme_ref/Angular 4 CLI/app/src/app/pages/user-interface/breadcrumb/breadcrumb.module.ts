import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from "@angular/router";
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

import { BreadcrumbComponent } from "./breadcrumb.component";

const BREADCRUMBS_ROUTES = [
    { path: '', component: BreadcrumbComponent }
];

@NgModule ({
    declarations: [
        BreadcrumbComponent
    ],
    imports: [
        CommonModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(BREADCRUMBS_ROUTES)
    ]
})

export class BreadcrumbModule {  }