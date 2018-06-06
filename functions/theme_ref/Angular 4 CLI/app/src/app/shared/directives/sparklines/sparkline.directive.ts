import { Directive, Input, ElementRef } from "@angular/core";
declare var jQuery: any;

@Directive ({
    selector: 'sparkline'
})

export class SparklineDirective {
    @Input() private type:string;
    @Input() private options:any;
    @Input() private dataset:any;

    constructor(private el: ElementRef) {}

    ngOnInit() {
        let initSparkline = jQuery(this.el.nativeElement);

        // Initiate Sparkline Chart
        initSparkline.sparkline(
            this.dataset,
            this.options
        )
    }
}