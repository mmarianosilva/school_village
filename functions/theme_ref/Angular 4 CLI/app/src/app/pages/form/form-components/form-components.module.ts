import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { SharedModule } from "../../../shared/shared.module";
import { TextMaskModule } from 'angular2-text-mask';
import { Select2Module } from 'ng2-select2';
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';
import { NouisliderComponent } from 'ng2-nouislider';
import { FormComponentsComponent } from './form-components.component';

const FORM_COMPONENTS_ROUTES = [
    { path: '', component: FormComponentsComponent }
];

@NgModule ({
    declarations: [
        FormComponentsComponent,
        NouisliderComponent
    ],
    imports: [
        CommonModule,
        SharedModule,
        FormsModule,
        TextMaskModule,
        Select2Module,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(FORM_COMPONENTS_ROUTES)
    ]
})

export class FormComponentsModule {

}