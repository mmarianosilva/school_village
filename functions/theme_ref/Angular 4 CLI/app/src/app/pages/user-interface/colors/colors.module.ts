import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from "@angular/router";
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

import { ColorsComponent } from "./colors.component";

const COLORS_ROUTES = [
    { path: '', component: ColorsComponent }
];

@NgModule ({
    declarations: [
        ColorsComponent
    ],
    imports: [
        CommonModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(COLORS_ROUTES)
    ]
})

export class ColorsModule {  }