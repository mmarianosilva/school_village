import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

import { CssAnimationsComponent } from "./css-animations.component";

const CSSANIMATIONS_ROUTES = [
    { path: '', component: CssAnimationsComponent }
]

@NgModule ({
    declarations: [
        CssAnimationsComponent
    ],
    imports: [
        CommonModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(CSSANIMATIONS_ROUTES)
    ]
})

export class CssAnimationsModule {  }