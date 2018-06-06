import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { PaginationModule } from 'ngx-bootstrap/pagination';
import { Ng2TableModule } from 'ng2-table/ng2-table';

import { DataTableComponent } from './data-table.component';

const DATATABLE_ROUTES: Routes = [
    { path: '', component: DataTableComponent }
];

@NgModule ({
    declarations: [
        DataTableComponent
    ],
    imports: [
        CommonModule,
        FormsModule,
        PaginationModule.forRoot(),
        Ng2TableModule,
        RouterModule.forChild(DATATABLE_ROUTES)
    ]
})

export class DataTableModule { }