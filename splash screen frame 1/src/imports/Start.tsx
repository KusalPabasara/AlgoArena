import svgPaths from "./svg-welm592oas";
import imgLeo11 from "figma:asset/b21f12ea7cc43794e9cf7e2fd0b7d65edd5d2728.png";
import imgSriLankaMaldivesBlackVersion11 from "figma:asset/ecdb504277aec0a0770fe673bd30ee140ff41be2.png";
import img3F3F7674Ead2Dca54Ee11Da58Cb3D19Ssssb1 from "figma:asset/89fd46e320e112a248b7b9b635bea47866513aa5.png";

function Bar() {
  return (
    <div className="absolute contents left-[132px] top-[861px]" data-name="Bar">
      <div className="absolute bg-black h-[5.442px] left-[132px] rounded-[34px] top-[861px] w-[145.848px]" data-name="Bar" />
    </div>
  );
}

function Group1() {
  return (
    <div className="absolute contents left-[-194px] top-[473px]">
      <div className="absolute h-[64px] left-[402px] top-[473px] w-[67px]" data-name="leo1 1">
        <img alt="" className="absolute inset-0 max-w-none object-50%-50% object-cover pointer-events-none size-full" src={imgLeo11} />
      </div>
      <div className="absolute h-[64px] left-[-194px] top-[473px] w-[188px]" data-name="-SriLanka-Maldives-Black-Version-1 1">
        <img alt="" className="absolute inset-0 max-w-none object-50%-50% object-cover pointer-events-none size-full" src={imgSriLankaMaldivesBlackVersion11} />
      </div>
    </div>
  );
}

function Group() {
  return (
    <div className="absolute h-[32.195px] left-[192px] top-[725px] w-[33px]">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 33 33">
        <g id="Group 1000004651">
          <circle cx="6.43902" cy="6.43902" fill="var(--fill-0, #004CFF)" id="Ellipse 153" r="6.43902" />
          <circle cx="6.43902" cy="25.7561" fill="var(--fill-0, #FCB700)" id="Ellipse 154" r="6.43902" />
          <circle cx="26.561" cy="25.7561" fill="var(--fill-0, #00D390)" id="Ellipse 155" r="6.43902" />
          <circle cx="26.561" cy="6.43902" fill="var(--fill-0, #F43098)" id="Ellipse 156" r="6.43902" />
        </g>
      </svg>
    </div>
  );
}

function Border() {
  return (
    <div className="absolute bottom-0 left-0 right-[2.33px] top-0" data-name="Border">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 22 12">
        <g clipPath="url(#clip0_1_88)" id="Border">
          <g id="Shape"></g>
          <mask height="12" id="mask0_1_88" maskUnits="userSpaceOnUse" style={{ maskType: "alpha" }} width="22" x="0" y="0">
            <path d={svgPaths.p260541f0} fill="var(--fill-0, black)" id="Shape_2" />
          </mask>
          <g mask="url(#mask0_1_88)">
            <path d={svgPaths.p2ca600} id="Fill" stroke="var(--stroke-0, black)" strokeOpacity="0.34902" strokeWidth="2" />
          </g>
        </g>
        <defs>
          <clipPath id="clip0_1_88">
            <rect fill="white" height="11.3333" width="22" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Cap() {
  return (
    <div className="absolute h-[4px] right-0 top-1/2 translate-y-[-50%] w-[1.328px]" data-name="Cap">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 2 4">
        <g id="Cap">
          <g id="Shape"></g>
          <mask height="4" id="mask0_1_83" maskUnits="userSpaceOnUse" style={{ maskType: "alpha" }} width="2" x="0" y="0">
            <path d={svgPaths.p2b99ae00} fill="var(--fill-0, black)" id="Shape_2" />
          </mask>
          <g mask="url(#mask0_1_83)">
            <path d="M-5 -5H6.328V9H-5V-5Z" fill="var(--fill-0, black)" fillOpacity="0.4" id="Fill" />
          </g>
        </g>
      </svg>
    </div>
  );
}

function Capacity() {
  return (
    <div className="absolute h-[7.333px] left-[2px] top-1/2 translate-y-[-50%] w-[18px]" data-name="Capacity">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 18 8">
        <g id="Capacity">
          <g id="Shape"></g>
          <mask height="8" id="mask0_1_78" maskUnits="userSpaceOnUse" style={{ maskType: "alpha" }} width="18" x="0" y="0">
            <path d={svgPaths.p8246f00} fill="var(--fill-0, black)" id="Shape_2" />
          </mask>
          <g mask="url(#mask0_1_78)">
            <path d="M-5 -5H23V12.3333H-5V-5Z" fill="var(--fill-0, black)" id="Fill" />
          </g>
        </g>
      </svg>
    </div>
  );
}

function Battery() {
  return (
    <div className="absolute h-[11.333px] overflow-clip right-[27.67px] top-[calc(50%+1px)] translate-y-[-50%] w-[24.328px]" data-name="Battery">
      <Border />
      <Cap />
      <Capacity />
    </div>
  );
}

function Wifi() {
  return (
    <div className="absolute h-[10.966px] overflow-clip right-[54.03px] top-[calc(50%+0.81px)] translate-y-[-50%] w-[15.272px]" data-name="Wifi">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 16 11">
        <g clipPath="url(#clip0_1_93)" id="Wifi">
          <g id="Shape"></g>
          <mask height="11" id="mask0_1_93" maskUnits="userSpaceOnUse" style={{ maskType: "luminance" }} width="16" x="0" y="0">
            <path clipRule="evenodd" d={svgPaths.p35f5d700} fill="var(--fill-0, white)" fillRule="evenodd" id="Shape_2" />
          </mask>
          <g mask="url(#mask0_1_93)">
            <path d={svgPaths.p592eaf0} fill="var(--fill-0, black)" id="Fill" />
          </g>
        </g>
        <defs>
          <clipPath id="clip0_1_93">
            <rect fill="white" height="10.9656" width="15.2724" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function CellularConnection() {
  return (
    <div className="absolute h-[10.667px] left-[calc(50%+104.17px)] overflow-clip top-[calc(50%+1px)] translate-x-[-50%] translate-y-[-50%] w-[17px]" data-name="Cellular Connection">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 17 11">
        <g clipPath="url(#clip0_1_65)" id="Cellular Connection">
          <g id="Shape"></g>
          <mask height="11" id="mask0_1_65" maskUnits="userSpaceOnUse" style={{ maskType: "luminance" }} width="17" x="0" y="0">
            <path clipRule="evenodd" d={svgPaths.p35ce9400} fill="var(--fill-0, white)" fillRule="evenodd" id="Shape_2" />
          </mask>
          <g mask="url(#mask0_1_65)">
            <path d="M-8 -5H19V15.6667H-8V-5Z" fill="var(--fill-0, black)" id="Fill" />
          </g>
        </g>
        <defs>
          <clipPath id="clip0_1_65">
            <rect fill="white" height="10.6667" width="17" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function BarsTimeBlack() {
  return (
    <div className="absolute inset-[29.55%_80%_29.55%_5.6%] overflow-clip" data-name="Bars/_/Time Black">
      <div className="absolute bottom-[1.64px] left-0 right-[-0.11px] top-0" data-name="Background">
        <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 32 32">
          <g id="Background"></g>
        </svg>
      </div>
      <p className="absolute font-['Nunito_Sans:SemiBold',sans-serif] font-semibold h-[16px] leading-[normal] left-0 right-0 text-[14px] text-black text-center top-[calc(50%-6.82px)] tracking-[0.0039px]" style={{ fontVariationSettings: "'YTLC' 500, 'wdth' 100" }}>
        9:41
      </p>
    </div>
  );
}

function BarsStatusBarLightStatusBar() {
  return (
    <div className="absolute h-[48px] left-0 overflow-clip top-0 w-[402px]" data-name="Bars/Status Bar/Light Status Bar">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 32 32">
        <g id="Background"></g>
      </svg>
      <Battery />
      <Wifi />
      <CellularConnection />
      <BarsTimeBlack />
    </div>
  );
}

export default function Start() {
  return (
    <div className="bg-[rgba(248,248,248,0.98)] relative size-full" data-name="Start">
      <Bar />
      <Group1 />
      <div className="absolute h-[884px] left-[-310px] top-[-5px] w-[736px]" data-name="3f3f7674ead2dca54ee11da58cb3d19ssssb 1">
        <img alt="" className="absolute inset-0 max-w-none object-50%-50% object-cover pointer-events-none size-full" src={img3F3F7674Ead2Dca54Ee11Da58Cb3D19Ssssb1} />
      </div>
      <Group />
      <BarsStatusBarLightStatusBar />
    </div>
  );
}
