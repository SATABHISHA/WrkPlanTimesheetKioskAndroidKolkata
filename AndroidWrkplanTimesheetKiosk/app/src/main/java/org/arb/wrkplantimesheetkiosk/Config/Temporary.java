package org.arb.wrkplantimesheetkiosk.Config;


import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

public class Temporary {
    public static String imagetemp = "iVBORw0KGgoAAAANSUhEUgAAAMMAAAEECAIAAAAahxdFAAAAA3NCSVQICAjb4U/gAAAgAElEQVR4\n" +
            "    nDS73ZJlSXKdt/wvYp+TmVXV0xjMDGADgiBE0iSakVcS3/8dZLoQSUmkRGAGg56uqsxz9o5w96WL\n" +
            "    ll4gzG2ZhYWHf5/Lf4xX15eY/cyPxuda+1c/xn9/f1btN6AsErKl5JEdo5jjt6+PPz//zPXXv/7N\n" +
            "    r990VDtGtaEc/lF1P0d747Xr0fH0by/5YrPf+7X8Z33WD2b0CQOv+mrtkPvFNZ+Wd8bSK8rHYfxn\n" +
            "    yhvOSDklb/Fy9cJW817l2juclv7UMG3wmmIf7NetJSqG1VUWsnA/9re1/KU/7Rt6/hQf8xr0cils\n" +
            "    eQx7085t4N4+C3sUusQrS+ymghQbtU98vBBqo7CaKvOTXD91vHB3MjHHyGWVuxVui8+D95QYnT0C\n" +
            "    vZpDK9XJPXqWm+wPFT/VqnZ4c4U6bHCf9Fswea663fWZesfjw+c966vFG9T6XDW0S6ftumIJQphx\n" +
            "    HhbV22WWSn2Y4pvFC+Us+7yS917fA8clmDWIZ5toaxLHm/CftH9oOzsFg1aySw44zTe6xN7yseNl\n" +
            "    z4XnJ8g5+9nrDp5qCDkve0nCDf7I55v9xm6v5l/Xt1QhcIwS1ZXnbbwi9xB9+9WXn799fRthkPF2\n" +
            "    XMav364ff/X50yd3qDKO1qeAQyR1+0jKcJd+3uQ2juoOJS+Wx/qLcX9cNdFdrUa4zhRJPXSIhaBx\n" +
            "    0bsVHSCqQ0IIWbysRdLIoe7I3hJicnbcdhkzF92cfLX4qEUPS7j3Mh7mxm4dG4uWltrVnyEl7e0q\n" +
            "    olUmrlh1lk58wETkZeg7eZ9a0qpW5rpPhl0qwl6SCxLaLTYZKvkhchelEJpxcydEy0ZR2ku3bW0R\n" +
            "    GVXSI7Wg7QwT0XCUUNYVcQh8cd85gtrSlqpaSKPIkJLMlD3gq/2AsBkjTraaDQ1RATkzr73nmJfK\n" +
            "    QTvRgbosb3ZczpB2ZtBVkfHcvA1AhFO0UgC5WbXAmCLuLdsUkb4KKmL8Z230pol2GITAaGObZbZN\n" +
            "    8a0xX7/mu7vd9BY7Xz5/+t3f/lsrnt+fNYRVf/zjP47hGv6//M//0e+fvn8vHfzyNl/abxoheiEP\n" +
            "    o7LdDqk9LLnXohG7ngw1F33BNRPX+x4WgMICzoEF4Lg70nptQBEI71TcIWoBdLERWmZW0YhiKSyG\n" +
            "    JbaMRteZdINUHjbXVRgqTo2URMOMYMZzUZuzct7cXUmU9VAxSAy1qrQePhv11rK6N0+lbOLZuQxo\n" +
            "    Wk2FjF6WNeL+WX2r2lGM7ZQSmvdncIShpaquxtQWWglSGALQxCCLq5nqSgzouQExn+Px6Edlbpyd\n" +
            "    Q6KzdGyBK9Bq+2TY4BAwDjeoOmPvDaM261pZD6+9Ibfbizz6djaaUDGzKFixemnZAto1o3fJzYXc\n" +
            "    md0on3p5W24AgDXqVN2Gx1MDgy7Pa1+DLxoG4WUD3qucZwlGWDX2Evs17vfXGdmV6/Nf/La2/pf/\n" +
            "    /o/Xfn4OW8Z7jHAj8Zu/+v1//sM/cvCPP3/98ct8/fz5U1oroSJuJcJmmoQbaoeN2uM2cQVnobLv\n" +
            "    Ez392VO4YbYsUvp182E6RS5pgK5mYUVV7hO6XXBRgxd6bhczVaA6gIUF8qvlESY+hrRBlQZz6uHc\n" +
            "    fgClGu2M3TY0wCUhJKPGFQnoBrpoSoIl7WpOeZHDpMU4qG3GJjFENnTs3AEdw7MKqhTactjloh0y\n" +
            "    tHpLAWfhbgMUFlmmLuri6pUVQ0TgplcYUV4iAtUMhKJwCyhU66raLu5UjhQ5SPrns3aZOIV6fW+q\n" +
            "    lxo2OfqGIPXCFg23qrsrrVPpMqwyVHu3Wkkfc1Kq38lPGmFQS2I4rMnsnKEHLeQ4ZYdYsu8W3NzK\n" +
            "    Nt6G3tqJFmc0YRSPMHGJw+g67be36OsMm1vz61l95vIllBfXq2ydS0uurvPbd3+d1fX1/eM3v/mV\n" +
            "    6/1GlgBSQ7hcK+zJDeWQGJ7SIyMpNJjZ6N7aM8Zwaza81EV+UF0W6+OCqRo1ZZtul9jPS11NXHUo\n" +
            "    UW6hAoZ69iWKNp1z5hijKrefe89pG9Zy5qluu0FxZiJah8/kZcNTWgiWhu+QSMj0XdBuRMJFQAgs\n" +
            "    zJ5SU46vvAZCNk9vS30zS2kAQX3IyTaIv+p2nc1diQszhrSrdwIKUVcB2Va6a4gI6lpUMUUmbLSM\n" +
            "    JqkZ4qGLap2z0aOVoZ0bNtAhqApj2ugSgeQQdWBJ2DAlxTp8cIGoC2umbSm6CnuzQaoqymxG7KfS\n" +
            "    lBa619aSU0VJUVc0JMRSNyoGx65leuPOUW4eg+txNsZpD/Mw2r7YppooY11d2+2v3o5D5rnPUr66\n" +
            "    f/r1j/Hl8/Of//yO+v3v/gWbzaLxEByvLx/r+n6tH374/Cmn3JvWr/ugrqq+4C2YlMHq3pjt5HR8\n" +
            "    712SRififb1PWKnc0hSydQllO61CDDWNRineRNV8pBoEySO8pe4ysKpnyQ7XgrjufhFRGVApyAU1\n" +
            "    4Rwuvgm5MoaLpW9bTy9cfHHbrRFUWJucnYNa28cwYRTap32spmq55sWhDmJYp8UoaiC9LGHlfgRO\n" +
            "    tqYlXZklSQ6Nzcuq3MymlrGXbuRUZ1ubhZmIwXRUr6a3usLUF1qgmRWlKRlQl0FtG5bMK3VMSG+x\n" +
            "    S1puarOaOkDzXSbiiQfsFnaidNy0jNYRcQifHcIerpdGmiqSODbbtGUMCKb6MzdQYcI21z7JoRba\n" +
            "    VGNRJ8/cUBE5ju3vft73C0ixISxqQomWfbj9NjR6xuyVLd388mLx6fr5p6fh4+tXQV2scxeI6+V4\n" +
            "    5+onf/jVffQgtkCR3soQAU0b01aAzdkQWZpd9DCVwP7mcTtUq9KXtiR5za1SuU2I8m1GQQ+GCJ5O\n" +
            "    LQ311E7bXVwQRIuIlANlAlEV0sv3yCpBqK06tFmaowdjW2na9lVI04hFhXcv6ReTXS0a6py5V6qZ\n" +
            "    dTZO01FoUfE8qrbn1NAmtEpwVofaFg/oOMYImKBFTsF0mrTw8IEuLa1cNj3K6yhkswUQVPZwL1KP\n" +
            "    GSKnbs3eLkEbNFbdh6BRHdoNsqc6DL0+qG7Wa/c2uJ7FV8DVTBEq3ZaS2ao0wKEIdj2V9BfRazhN\n" +
            "    tVQtz2rxcJcNjDIoTkxTrZ0KdadhnpuuF68hxlwSw6U7NbQ3Gg5H5al8E26vplLtqWV/o/MQt2FX\n" +
            "    UQTgtSH18f6sHpAt+aJ+u49zN354fT6+C/V3f/mphr5sLdUrWEsxnwWKxBtQyFW3qRgiUvN29GNb\n" +
            "    iRyN0UWz1VVublsGZh5sBwSa0aTYYxNImhahxS1PeriNh5BqmmaWOUxdqrsQ3UzjIb6Eby7NQVTa\n" +
            "    KG51cWlavwSi7eQQzR4SYtDSHi1JhoU2t0uZBtphEirgdvHL89gO5VIepkUVsN29Fquz12iFB7VI\n" +
            "    bBGVab2EqiqgFU8iTYslPkYZzqy5uabs3uDOFo0xIdYXVAFeAWvQ5YA9ISqAnn0phvryESF2bOEw\n" +
            "    LeBMip+LQ6BP8BBTK7vUBXkUa95QAvypy5fe0E+lhSS0G3e4bT7xgI0WmSK7xCGr66k9YC7x7L6Z\n" +
            "    P6ocLOg0/WC5mcK2snFdHmOLhFmmXpvT4+f3x1TsyiD9eg6Vu5orSvglXnTt1yO0Vggq+KqCzoig\n" +
            "    a1DGGMQdLbd2kRA7Rkj2ddUS3dfJlnZ37TYFoC2DAhlWlzJDQmWAjq0uPO4qQ8dMdXfl0vCb+AWQ\n" +
            "    bRdEBKZQ+XNtD2G53VibYjotluwHc4s09RSTx3ossUalqBFePgJqrbmvLbusdQtPVbVJ16ptaKGS\n" +
            "    ZcDWafDuNrMBDUQKYYhmiZoAw5dhtw1r0VlpJgsARR7rgqm4OQVyqM1zr4a8Ha6DXnozMdG7jCcb\n" +
            "    jClm9jSNB2QZdu93XgfVS93dfNxL72HW1Z0hjZV07cFObu1S9kolZHGMpnKnPnqXAip3xl11iO3E\n" +
            "    aEA6EFU74JPD+5zAE0/M+F4UQ4Qotce20Xvg9Zjo9pK45HbXO1hs";


}
