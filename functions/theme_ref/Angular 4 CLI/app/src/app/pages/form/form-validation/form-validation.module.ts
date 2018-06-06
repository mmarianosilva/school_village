import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { SharedModule } from "../../../shared/shared.module";
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

import { FormValidationComponent } from "./form-validation.component";

const FORM_VALIDATION_ROUTES = [
    { path: '', component: FormValidationComponent }
];

@NgModule ({
    declarations: [
        FormValidationComponent
    ],
    imports: [
        CommonModule,
        SharedModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(FORM_VALIDATION_ROUTES)
    ]
})

export class FormValidationModule {  }