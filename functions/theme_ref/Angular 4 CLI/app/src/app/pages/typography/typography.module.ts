import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from "@angular/router";
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

import { TypographyComponent } from './typography.component';

const TYPOGRAPHY_ROUTES = [
    { path: '', component: TypographyComponent }
];

@NgModule ({
    declarations: [
        TypographyComponent
    ],
    imports: [
        CommonModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(TYPOGRAPHY_ROUTES)
    ]
})

export class TypographyModule {  }