import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-css-animations',
  templateUrl: './css-animations.component.html',
  styleUrls: ['./css-animations.component.scss']
})
export class CssAnimationsComponent implements OnInit {
  animationClasses: any = {
    attentionSeekers: '',
    flippers: '',
    lightSpeed: '',
    specials: '',
    bouncingEntrances: '',
    bouncingExits: '',
    rotatingEntrances: '',
    rotatingExits: '',
    fadingEntrances: '',
    fadingExits: '',
    zoomEntrances: '',
    zoomExits: ''
  }
  animationDuration: number = 0

  setAnimation(animationGroup, animation) {
    this.animationClasses[animationGroup] = animation
    this.animationDuration = animation === 'hinge' ? 2100 : 1200

    setTimeout(() => {
      this.animationClasses[animationGroup] = ''
    }, this.animationDuration)
  }

  constructor() { }

  ngOnInit() {
  }

}
