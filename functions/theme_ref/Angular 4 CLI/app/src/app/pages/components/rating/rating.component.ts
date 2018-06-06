import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-rating',
  templateUrl: './rating.component.html',
  styleUrls: ['./rating.component.scss']
})
export class RatingComponent implements OnInit {
  ratingsValue: number = 5

  max:number = 10;
  rate:number = 7;
  isReadonly:boolean = false;

  overStar:number;
  percent:number;

  hoveringOver(value:number):void {
    this.overStar = value;
    this.percent = 100 * (value / this.max);
  };

  resetStar():void {
    this.overStar = void 0;
  }

  constructor() { }

  ngOnInit() {
  }

}
