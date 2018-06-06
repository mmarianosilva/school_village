import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { SharedModule } from "../../../shared/shared.module";
import { Autosize } from 'ng-autosize';
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

import { FormElementsComponent } from './form-elements.component';

const FORM_ELEMENTS_ROUTES = [
    { path: '', component: FormElementsComponent }
];

@NgModule ({
    declarations: [
        FormElementsComponent,
        Autosize
    ],
    imports: [
        CommonModule,
        SharedModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(FORM_ELEMENTS_ROUTES)
    ]
})

export class FormElementsModule {  }