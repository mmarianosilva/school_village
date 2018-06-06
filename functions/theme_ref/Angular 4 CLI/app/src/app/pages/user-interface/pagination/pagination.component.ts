import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-pagination',
  templateUrl: './pagination.component.html',
  styleUrls: ['./pagination.component.scss']
})
export class PaginationComponent implements OnInit {
  paginTotalItems: number = 64;
  paginCurrentPage: number = 4;
  paginNumPages: number = 0;

  paginMaxSize:number = 5;
  paginBigTotalItems:number = 175;
  paginBigCurrentPage:number = 1;


  setPage(pageNo: number): void {
    this.paginCurrentPage = pageNo;
  }

  pageChanged(event: any): void {
    console.log('Page changed to: ' + event.page);
    console.log('Number items per page: ' + event.itemsPerPage);
  }
  constructor() { }

  ngOnInit() {
  }

}
