import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'widget-photos',
  templateUrl: './photos.component.html',
  styleUrls: ['./photos.component.scss']
})
export class PhotosComponent implements OnInit {
  picturesData: any;

  constructor() {

    this.picturesData = [
      './assets/demo/img/widgets/headers/1.png',
      './assets/demo/img/widgets/headers/2.png',
      './assets/demo/img/widgets/headers/3.png',
      './assets/demo/img/widgets/headers/4.png',
      './assets/demo/img/widgets/headers/5.png',
      './assets/demo/img/widgets/headers/6.png',
      './assets/demo/img/widgets/headers/7.png',
      './assets/demo/img/widgets/headers/8.png',
      './assets/demo/img/widgets/headers/9.png'
    ]

  }

  ngOnInit() {
  }

}
