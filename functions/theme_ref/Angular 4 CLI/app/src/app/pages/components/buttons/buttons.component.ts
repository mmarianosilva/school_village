import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-buttons',
  templateUrl: './buttons.component.html',
  styleUrls: ['./buttons.component.scss']
})
export class ButtonsComponent implements OnInit {
  buttonSingleModel: string = '0';
  buttonCheckModel:any = {
    left: false,
    middle: true,
    right: false
  };
  buttonRadioModel: string = 'Middle';

  constructor() { }

  ngOnInit() {
  }

}
