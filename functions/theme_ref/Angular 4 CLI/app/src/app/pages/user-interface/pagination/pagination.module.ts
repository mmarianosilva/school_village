import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from "@angular/router";
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

import { PaginationComponent } from "./pagination.component";

const PAGINATION_ROUTES = [
    { path: '', component: PaginationComponent }
];

@NgModule ({
    declarations: [
        PaginationComponent
    ],
    imports: [
        CommonModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(PAGINATION_ROUTES)
    ]
})

export class PaginationsModule {  }